import { Link } from '@inertiajs/react'
import { Text, Box } from '@mantine/core'

export default function Landing({ godFatherImageUrl, taxiDriverImageUrl }) {
  return (
    <Box
      style={{
        height: '100vh',
        display: 'flex',
        flexDirection: 'row',
        background: '#080610',
        overflow: 'hidden',
      }}
    >
      {/* Left: Don portrait */}
      <Box
        style={{
          flex: '0 0 45%',
          position: 'relative',
          overflow: 'hidden',
        }}
      >
        <Box
          component="img"
          src={godFatherImageUrl}
          alt=""
          style={{
            position: 'absolute',
            inset: 0,
            width: '100%',
            height: '100%',
            objectFit: 'cover',
            objectPosition: 'center top',
            display: 'block',
          }}
        />
        <Box
          style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(to right, rgba(5,3,10,0.10) 40%, rgba(8,6,16,1) 100%)',
          }}
        />
        <Box
          style={{
            position: 'absolute',
            inset: 0,
            background: 'linear-gradient(to top, rgba(5,3,10,0.6) 0%, transparent 40%)',
          }}
        />
      </Box>

      {/* Right: report panel */}
      <Box
        style={{
          flex: 1,
          display: 'flex',
          flexDirection: 'column',
          justifyContent: 'center',
          alignItems: 'flex-start',
          padding: '0 80px',
          gap: 48,
        }}
      >
        {/* Title block */}
        <Box>
          <Text
            style={{
              fontFamily: '"Cinzel", serif',
              fontSize: 14,
              letterSpacing: '0.3em',
              color: '#5A4E3A',
              textTransform: 'uppercase',
              marginBottom: 14,
            }}
          >
            Il Consiglio Privato
          </Text>
          <Text
            style={{
              fontFamily: '"Cinzel", serif',
              fontSize: 88,
              fontWeight: 700,
              color: '#C9A84C',
              letterSpacing: '0.08em',
              lineHeight: 1,
              textShadow: '0 2px 48px rgba(201,168,76,0.25)',
            }}
          >
            CONSIGLIERE
          </Text>
          <Text
            style={{
              fontFamily: '"EB Garamond", Georgia, serif',
              fontStyle: 'italic',
              fontSize: 26,
              color: '#5A4E3A',
              marginTop: 14,
              letterSpacing: '0.03em',
            }}
          >
            Vaša osobná spravodajská služba
          </Text>
        </Box>

        {/* Divider */}
        <Box style={{ height: 1, background: 'rgba(201,168,76,0.15)', width: '100%', maxWidth: 480 }} />

        {/* Operative report */}
        <Box style={{ display: 'flex', gap: 28, alignItems: 'flex-start' }}>
          <Box
            style={{
              width: 110,
              height: 134,
              flexShrink: 0,
              overflow: 'hidden',
              border: '1px solid rgba(201,168,76,0.25)',
              filter: 'sepia(0.25) contrast(1.1)',
            }}
          >
            <Box
              component="img"
              src={taxiDriverImageUrl}
              alt="Agent"
              style={{
                width: '100%',
                height: '100%',
                objectFit: 'cover',
                objectPosition: 'top center',
                display: 'block',
              }}
            />
          </Box>

          <Box style={{ flex: 1 }}>
            <Text
              style={{
                fontFamily: '"Cinzel", serif',
                fontSize: 13,
                letterSpacing: '0.25em',
                color: '#5A4E3A',
                textTransform: 'uppercase',
                marginBottom: 14,
              }}
            >
              Hlásenie agenta
            </Text>
            <Text
              style={{
                fontFamily: '"EB Garamond", Georgia, serif',
                fontSize: 26,
                lineHeight: 1.75,
                color: '#DDD0B8',
              }}
            >
              Don, sledoval som súperné rodiny. Ich akcie,
              ich slabiny, ich pohyby — všetko zaznamenané.
            </Text>
          </Box>
        </Box>

        {/* Quote */}
        <Text
          style={{
            fontFamily: '"EB Garamond", Georgia, serif',
            fontStyle: 'italic',
            fontSize: 22,
            color: '#5A4E3A',
            lineHeight: 1.7,
            borderLeft: '2px solid rgba(201,168,76,0.20)',
            paddingLeft: 24,
            maxWidth: 560,
          }}
        >
          „Nechaj pištoľ. Vezmi cannoli."
          <br />
          <span style={{ fontSize: 18 }}>— a správy.</span>
        </Text>

        {/* CTA */}
        <Link
          href="/admin/competitor_monitoring/competitors"
          style={{ textDecoration: 'none', display: 'inline-block' }}
        >
          <Box
            style={{
              background: '#C9A84C',
              color: '#0B0910',
              fontFamily: '"Cinzel", serif',
              fontSize: 16,
              fontWeight: 700,
              letterSpacing: '0.15em',
              textTransform: 'uppercase',
              padding: '18px 48px',
              cursor: 'pointer',
              transition: 'background 0.15s',
            }}
            onMouseEnter={e => { e.currentTarget.style.background = '#B8960C' }}
            onMouseLeave={e => { e.currentTarget.style.background = '#C9A84C' }}
          >
            Vstúpiť do pracovne
          </Box>
        </Link>

        {/* Bottom motto */}
        <Text
          style={{
            fontFamily: '"Cinzel", serif',
            fontSize: 13,
            letterSpacing: '0.3em',
            color: '#2A2018',
            textTransform: 'uppercase',
          }}
        >
          Omertà · Lealtà · Rispetto
        </Text>
      </Box>
    </Box>
  )
}
